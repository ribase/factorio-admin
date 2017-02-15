<?php

namespace Ribase\Controller;

use Ribase\Options\Settings;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Form\Extension\Core\Type\FileType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;

class ModController extends Controller
{


    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\RedirectResponse|\Symfony\Component\HttpFoundation\Response
     * @Route("/mods", name="Mods")
     */
    public function listAction(Request $request)
    {
        $path = $this->getModDir();
        $finder = new Finder();
        $finder->files()->in($path);

        $form = $this->createFormBuilder()
            ->add('attachment', FileType::class, array(
                'attr' => array('class' => 'button'),
                'required'    => false,
            ))
            ->add('save', SubmitType::class, array(
                'attr' => array('class' => 'success button'),
            ))
            ->setMethod('POST')
            ->getForm();

        $fileNames = array();

        foreach ($finder as $file) {
            // Dump the absolute path
            $fileNames[]= $file->getFileName();
        }

        if ($request->isMethod('POST')) {
            $form->submit($request->request->get($form->getName()));

            if ($form->isSubmitted()) {

                $content = $request->request->get('form');
                foreach($request->files as $uploadedFile) {
                    if($uploadedFile["attachment"])
                    {
                        $name = $uploadedFile["attachment"]->getClientOriginalName();
                        $file = $uploadedFile["attachment"]->move($path, $name);
                    }

                }

                foreach($content as $key => $value)
                {

                    if($value == "DELETE")
                    {
                        $this->deleteFile($key);
                    }
                }
                return $this->redirect('/mods', 301);
            }
        }

        $response = $this->render('admin/mod.html.twig', array(
            'view' => $fileNames,
            'form' => $form->createView(),
        ));

        $response->headers->addCacheControlDirective('no-cache', true);


        return $response;
    }

    /**
     * @param $file
     * @return bool
     */
    private function deleteFile($file)
    {

        if($file)
        {
            $rootdir = $this->getModDir();
            $fs = new Filesystem();

            if($fs->exists($rootdir.$file))
            {
                $fs->remove($rootdir.$file);
            }else{
                die( "something went wrong");
            }

            if($fs->exists($rootdir.$file))
            {
                die( "something went wrong");
            }else{
                return true;
            }
        }else {
            die( "something went wrong");
        }
    }

    /**
     * @return string
     */
    private function getModDir()
    {
        $settings = new Settings();

        return $settings->getMods();
    }
}