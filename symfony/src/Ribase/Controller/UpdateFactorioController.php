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

class UpdateFactorioController extends Controller
{

    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\RedirectResponse|\Symfony\Component\HttpFoundation\Response
     * @Route("/updatefactorio", name="Updatefactorio")
     */
    public function listAction(Request $request)
    {
        $path = $this->getFactorioDir();

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

        if ($request->isMethod('POST')) {
            $form->submit($request->request->get($form->getName()));

            if ($form->isSubmitted()) {
                foreach($request->files as $uploadedFile) {
                    if($uploadedFile["attachment"])
                    {
                        $name = $uploadedFile["attachment"]->getClientOriginalName();
                        $file = $uploadedFile["attachment"]->move($path."/update-folder/", $name);
                    }

                    if($file)
                    {
                        $this->installUpdate($name);
                    }

                }


                return $this->redirectToRoute('Updatefactorio', array(), 301);
            }
        }

        $response = $this->render('admin/updatefactorio.html.twig', array(
            'form' => $form->createView(),
        ));

        $response->headers->addCacheControlDirective('no-cache', true);


        return $response;
    }

    /**
     * @return bool|string
     */
    private function installUpdate($name)
    {
        $factorioPath = $this->getFactorioDir();

        $result = shell_exec($factorioPath.'/update.sh '.$name);

        if($result)
        {
            return true;
        }else {
            $result = shell_exec($factorioPath.'rollback.sh');

            if($result)
            {
                return true;
            }else {
                return "you are fucked, nice day, dont call support";
            }
        }

    }

    private function getFactorioDir()
    {
        $settings = new Settings();

        return $settings->getFactorioDir();
    }
}