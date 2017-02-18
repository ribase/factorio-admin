<?php

namespace Ribase\Controller;

use Ribase\Options\Settings;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\Serializer\Serializer;
use Symfony\Component\Serializer\Normalizer\ObjectNormalizer;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;

class ServerlogsController extends Controller
{


    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     * @Route("/serverlogs", name="Serverlogs")
     */
    public function listAction(Request $request)
    {
        $view = $this->getLogFile();
        $routeName = $request->get('_route');

        return $this->render('admin/serverlogs.html.twig', array(
            'pagetitle' => $routeName,
            'view' => $view,
        ));
    }

    /**
     * @return array
     */
    private function getLogFile()
    {
        $factorioPath = $this->getFactorioDir();

        $finder = new Finder();
        $finder->files()->name('factorio-current.log');
        $finder->files()->in($factorioPath);

        $contents = array();
        foreach ($finder as $file) {
            $content = $file->getContents();
            $content = str_replace("/var/opt/factorio", "../", $content);
            $content = explode(PHP_EOL, $content);
            $contents[] = $content;
        }

        return $contents;

    }

    private function getFactorioDir()
    {
        $settings = new Settings();

        return $settings->getFactorioDir();
    }
    
    
}